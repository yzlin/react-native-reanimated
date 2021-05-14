import React, { useState } from 'react';
import classnames from 'classnames';
import useBaseUrl from '@docusaurus/useBaseUrl';
import Layout from '@theme/Layout';
import styles from './styles.module.css';

function Filter({ expanded: expandedInitial }) {
  const [expanded, setExpanded] = useState(!!expandedInitial);
  const [filter, setFilter] = useState({});

  const filterButton = (
    <>
      <button
        className={classnames(
          'button button--secondary button--lg',
          styles.filterButton
        )}
        onClick={() => setExpanded(!expanded)}>
        Filter ↑
      </button>
    </>
  );

  const filterExpanded = (
    <>
      <div className={styles.filter}>
        <article>
          <h2>Source code</h2>
          <button
            className={classnames(
              'button  button--lg',
              filter.available ? 'button--primary ' : 'button--outline'
            )}
            onClick={() =>
              setFilter({ ...filter, available: !filter.available })
            }>
            Available
          </button>
        </article>
        <button className="button button--primary button--lg margin-horiz--none">
          Show results
        </button>
        <button className={styles.resetFilters}>Reset filters</button>
      </div>
    </>
  );
  return (
    <>
      {filterButton}
      {expanded && filterExpanded}
    </>
  );
}

function Card({ title, name, link, platform }) {
  return (
    <>
      <article className={styles.card}>
        {/* <img src="https://picsum.photos/217/470" /> */}

        <div className={styles.cardImgContainer}>
          <img
            src={`https://picsum.photos/217/470?random=${link}`}
            className={styles.cardImg}
          />
        </div>
        <div className={styles.cardDescription}>
          <h2 className={styles.cardTitle}>{title}</h2>
          <p className={classnames(styles.cardAuthor, 'margin--none')}>
            by <span className={styles.cardTextNick}>{name}</span> on {platform}
          </p>
        </div>
      </article>
    </>
  );
}

function Showcase() {
  return (
    <Layout>
      <div className={styles.containerWrapper}>
        <div className={styles.container}>
          <Filter expanded={true} />
          <div className={styles.cardsGrid}>
            {Array.from(Array(12)).map((_, i) => (
              <Card
                key={i}
                title={
                  i % 2
                    ? 'Very long name that should describe what this demo is doing'
                    : 'Short and to the point name'
                }
                name="@JakubGonet"
                platform="Twitter"
                link={i}
              />
            ))}
          </div>
        </div>
      </div>
    </Layout>
  );
}
export default Showcase;
